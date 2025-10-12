import { auth } from "@/app/(auth)/auth";
import { BriefcaseIcon } from "@/components/icons";

export default async function WorkspacesPage() {
  const session = await auth();

  return (
    <div className="flex h-dvh w-full flex-col items-center justify-center gap-6 bg-background p-4">
      <div className="flex flex-col items-center gap-4 text-center">
        <div className="text-foreground">
          <BriefcaseIcon size={64} />
        </div>

        <div className="flex flex-col gap-2">
          <h1 className="font-semibold text-2xl">My Workspaces</h1>
          <p className="text-muted-foreground text-sm">
            Esta funcionalidade está em construção
          </p>
        </div>

        <div className="mt-4 flex flex-col gap-2 text-muted-foreground text-xs">
          <p>🚧 Em breve você poderá:</p>
          <ul className="list-inside list-disc text-left">
            <li>Organizar seus projetos em workspaces</li>
            <li>Colaborar com sua equipe</li>
            <li>Gerenciar múltiplos contextos de trabalho</li>
          </ul>
        </div>

        {session?.user && (
          <p className="mt-6 text-muted-foreground text-xs">
            Olá, {session.user.email}! Estamos trabalhando nisso para você.
          </p>
        )}
      </div>
    </div>
  );
}
